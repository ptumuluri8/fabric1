# Membership Services

The purpose of this document is to describe how Membership Services works. This document provides a description of the inherent features of Membership Services.

## Overview  

This section describes at a high-level what membership services (Membership Services) does in Hyperledger fabric. Membership Services is implemented in Hyperledger fabric under the membersrvc directory in fabric/, along with parts of core/client.

The Membership Services component provides the Registration, Identity Management and Auditability services to Hyperledger fabric.  It is a central component which turns Hyperledger fabric from a non-permissioned blockchain to a permissioned blockchain.

The major security features provided or assisted by Membership Services include:

* Issues certificates which may be used to authenticate and authorize identities to transact on a blockchain;  
* Allows an authenticated transactor on a block to remain anonymous, except when required by an auditor and preventing linking two transactions to the same transactor;  
* Allows an authorized  auditor to see the identity and content of specific transactions as required to meet regulatory requirements.

In Hyperledger fabric, Membership Services runs as a single process and has a single root certificate. Membership Services employs the use of digital signatures to ascertain the validity of transactions, and determine whether or not to allow a transaction into the system.  ECDSA is used for signatures and verification of each signature requires full PKIX checking. There are currently two types of signing certificates which are supported: enrollment certificates and transaction certificates. These are provided by the Enrollment Certificate Authority (ECA) and the Transaction Certificate Authority (TCA) components of Membership Services and each of these components currently has its own certificate signing certificates. When a validating peer in Hyperledger fabric (peer) starts and "enrolls" with membership services, the root certificates from each of these components is downloaded and added to the certificate chain of trust used to verify digital signatures.

Membership services executable can be found at fabric/build/bin/membersrvc.  When it is started, it reads from the membersrvc.yaml configuration file.  It persistently stores information at /var/hyperledger/production/.membersrvc directory (by default).

Its main GRPC APIs are to register, enroll, and get transaction certificates as described in more detail later in this section.

Conceptually, registration is like creating an invitation to a party and enrollment is accepting the invitation.  Registration may be performed by the same or different entities.  If performed by different entities, it is up to the registrar (i.e. the one who creates the invitation) to deliver the invitation to the invitee.  Both registration and enrollment must occur prior to transacting on the blockchain.

The following flow shows the current interactions between the major components: the node client SDK, membership services, peer, and chaincode.

![Reference architecture](../images/overall-client-flow.png)

The numbered steps in the above boxes are described below.

1. Enroll a pre-registered bootstrap ID.  This assumes that the bootstrap ID is in the membersrvc.yaml file and has registrar authority.  For example, see the ‘admin’ user in the default membersrvc.yaml.

2. Set this bootstrap ID as the registrar identity for the chain which is then used as the identity to dynamically register new identities to transact on the chain associated with the peer.  If this is running inside a web application, the bootstrap identity is the identity associated with the web application itself.  The web application now has authority to register and enroll new users which that have authenticated themselves to the web application.

3. A new user has been created (i.e. registered and enrolled).  Now this new user can transact on the blockchain.  In order to support unlinkability, the node client SDK requests a batch of transaction certificates and then uses a different transaction certificate for each transaction.  This request may have one or more attribute names.

4. The client has a batch of transaction certificates, each containing the name and value of the requested attributes.  Submit a transaction using one of the transaction certificates from the batch.  The transaction flows through the peers and to the chaincode instances.

5. The chaincode extracts attribute(s) to make authorization decisions.

6. Once the transaction has been committed to the ledger, an event is generated and received by the node client SDK.  It then queries to get the results of the transaction and returns it to the SDK caller.

The following sections describe these APIs in more detail.

### 1. Registration

  There are two ways to register an identity:

   * Manually edit the fabric/membersrvc/membersrvc.yaml and add a line to the eca.users section.  There must be one or more bootstrap users listed in this section.

   * Call the RegisterUser GRPC API which is defined in fabric/membersrvc/protos/ca.proto as shown below.  This can be used to register users or other types of identities (e.g. peer).  Note that this call must be issued by an identity with registrar authority for the type of identity being registered.

   ```go
   rpc RegisterUser(RegisterUserReq) returns (Token);

   message RegisterUserReq {
       Identity id = 1;
       Role role = 2;)
       string affiliation = 4;
       Registrar registrar = 5;
       Signature sig = 6;
   }

   message Registrar {
       Identity id = 1;
       repeated string roles = 2;
       repeated string delegateRoles = 3;
   }

   message Token {
        bytes tok = 1;
   }
```

   The input to RegisterUser (in RegisterUserReq) is:  
     * id - the name of the identity;  
     * role - the type of the identity (e.g. user, peer, etc);  
     * affiliation - a company, organization, or other affiliation of the identity;  
     * registrar - the identity of the caller who must have permission to register this type of identity; also includes the permissions the new identity has wrt registration;  
     * sig - the signature of the registrar.

   The output from RegisterUser is a Token which is used by the identity itself to perform enrollment.

### 2. Enrollment

  The only way to enroll is by calling the following GRPC method in fabric/membersrvc/protos/ca.proto:  

  ```go
  rpc CreateCertificatePair(ECertCreateReq) returns (ECertCreateResp);

  message ECertCreateReq {
        google.protobuf.Timestamp ts = 1;
        Identity id = 2;
        Token tok = 3;
        PublicKey sign = 4;
        PublicKey enc = 5;
        Signature sig = 6; // sign(priv, ts | id | tok | sign | enc)
  }

  message ECertCreateResp {
        CertPair certs = 1;
        Token chain = 2;
        bytes pkchain = 5;
        Token tok = 3;
        FetchAttrsResult fetchResult = 4;
  }
  ```

  The input to CreateCertificatePair is:  
    * ts - the timestamp;  
    * id - the name of the identity;  
    * tok - the token or secret returned from registration;  
    * sign - the public key associated with the identity’s signing key pair;  
    * enc - the public key associated with the identity’s encryption key pair;  
    * sig - the signature of the identity’s signing key.

  The output from CreateCertificatePair is an enrollment certificate (ECert) signed by the ECA’s public key.  The ECert can then be used to get transaction certificates (TCert), as described below.  These TCerts are used to transact on a blockchain with anonymity and unlinkability.  

### 3. Get Transaction Certificates with Attributes

   Transaction certificates (TCerts) support the following:  
   * Anonymity - the enrollment ID is not contained in a tcert;  
   * Unlinkability - no two transactions can be linked together;  
   * Attributes - an attribute is just a name/value pair, like a property.  A signature provides proof that the identity associated with the tcert owns the attribute.  For example, an attribute name might be bankA_accountID and the attribute value is the user’s account ID for bank A.

   Conceptually, a TCert is a child of an ECert.  A specific tcert can be released to an auditor without revealing the ECert or other TCerts.

   The GRPC call to make to get a batch of TCerts is as follows:

   ```go
   rpc CreateCertificateSet(TCertCreateSetReq) returns (TCertCreateSetResp);

   message TCertCreateSetReq {
        google.protobuf.Timestamp ts = 1;
        Identity id = 2; // corresponding ECert retrieved from ECA
        uint32 num = 3; // number of tcerts to create
        repeated TCertAttribute attributes = 4;
        Signature sig = 5; // sign(priv, ts | id | attributes | num)
   }

   message TCertAttribute {
        string attributeName = 1;
   }

   message TCertCreateSetResp {
        CertSet certs = 1;
   }

   message CertSet {
        google.protobuf.Timestamp ts = 1;
        Identity id = 2;
        bytes key = 3;
        repeated TCert certs = 4;
   }
   ```

   The input to CreateCertificateSet is:  
   * ts - the timestamp;  
   * id - the name of the identity;  
   * num - the number of TCerts to generate;  
   * attributes - the names of the attributes to put inside each TCert;   
   * sig - signature by the identities private key of signing key-pair.   

   The output from CreateCertificateSet is an array of TCerts which are crpytographically related to the parent ECert.  The client uses the CertSet.key field plus the ECert’s private key to generate a digital signature for the transaction which preserves anonymity of the client and unlinkability of the transaction.

### 4. Attribute Certificate Authority  
   The current implementation of the ACA, or Attribute Certificate Authority, reads attributes from the membersrvc.yaml file (see excerpt below).  Each identity with attributes must be listed in the aca.attributes section of this file.  In other words, it is not possible today to dynamically register an identity with an attribute.

   As the comment in this file says below, the current implementation is a temporary emulation and is not meant for production.

   ```
   # Attributes is a list of the valid attributes to each user, attribute certificate authority is emulated temporarily
   # using this file entries.
   # In the future an external attribute certificate authority will be invoked. The format to each entry is:
   #
   #     attribute-entry-#:{userid};{affiliation};{attributeName};{attributeValue};{valid from};{valid to}
   #
   # If {valid to} is empty the attribute never expire(s), if the {valid from} is empty the attribute is valid from the time zero.
   
   attributes:
      attribute-entry-0: diego;institution_a;company;ACompany;2015-01-01T00:00:00-03:00;;
      attribute-entry-1: diego;institution_a;position;Software Staff;2015-01-01T00:00:00-03:00;2015-07-12T23:59:59-03:00;
   ```
   
   
### Enabling TLS

If you wish to configure TLS with the Membership Services server, the following steps are required:

- Modify `$GOPATH/src/github.com/hyperledger/fabric/membersrvc/membersrvc.yaml` as follows:

```yaml
server:
     tls:
        cert:
            file: "/var/hyperledger/production/.membersrvc/tlsca.cert"
        key:
            file: "/var/hyperledger/production/.membersrvc/tlsca.priv"
```

To specify to the Membership Services (TLS) Certificate Authority (TLSCA) what X.509 v3 Certificate (with a corresponding Private Key) to use:

- Modify `$GOPATH/src/github.com/hyperledger/fabric/peer/core.yaml` as follows:

```yaml
peer:
    pki:
        tls:
            enabled: true
            rootcert:
                file: "/var/hyperledger/production/.membersrvc/tlsca.cert"
```

To configure the peer to connect to the Membership Services server over TLS (otherwise, the connection will fail).

- Bootstrap your Membership Services and the peer. This is needed in order to have the file *tlsca.cert* generated by the member services.

- Copy `/var/hyperledger/production/.membersrvc/tlsca.cert` to `$GOPATH/src/github.com/hyperledger/fabric/sdk/node`.

*Note:* If you cleanup the folder `/var/hyperledger/production` then don't forget to copy again the *tlsca.cert* file as described above.
   
