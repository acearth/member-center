# Requirements
1. Redis
2. Sidekiq
3. PostgreSQL (production)

## Start service

0. redis-server 
1. bundle exec sidekiq







# MEMBER CENTER for CAS
# User Login Steps
1. User open an internal website(APP) to login;
2. APP redirected to MC_login_URL;
3. User open MC_login_URL;
4. User submit login form to MC, and MC authenticated user and issued one ticket for user;
5. MC redirected to APP_callback_URL;
6. User request APP_callback_URL;
7. APP server got ticket passed by user;
8. APP server post an request to MC for verifying and authenticating the ticket;
9. When verified and authenticated this ticket, MC respond ticket-associated user information to APP server;
10. APP render user welcome page;

* see process flow picture form app/assets/images
# API specification
1. Login to Member Center
```
GET /login?app_id=xxx
```
2. Member Center ticket authentication
```
POST /auth
parameters:
    ticket: string;
    app_id:
    sign: sign = md5(app_id-ticket-credential).to_hex_form
*** Join app_id, ticket, credential by – (dash)
```

3. callback params
path is specified by third-party application owner. MC will redirected to this URL with following parameters:
- 1) ticket
- 2) sign: sign = md5(ticket-credential).to_hex_form

4. User information response
The response content needs negotiate with third-party applications. Currently, the response json format is:
```{
    seq: suquential number in member center,
    status:{
        code: 0 || 999< 0 stands for success>,
        msg: returned message conclusion
    },
    user:{  // optional, if request is bad, not 'user' field there.
        username: registered user name for login, may same as email prefix,
        employee_id: employee ID,
        email: user's email address
    },
    sign: MD5 of (seq, status, user<optional>, credential).to_hex_form

  }
  ```
  Example 1:
  ```
  {
      seq: 1234222211,
      status: {
          code: 0,
          msg:'success'
      },
  user: {
      username: 'arthur',
      employee_id: 'C214',
      email: 'an_x@worksap.co.jp'
      },
  sign: 'CAFEBABE12345678'
  }
  ```

  Example 2:
  ```
  {
      seq: 23423423424,
      status: {
          code: 999,
          msg: 'Invalid sign'
      },
      sign:'E1781234DAE'
  }
  ```


# Third-party Application Utilization Procedure
  1. Register one user on Member Center;
  2. Register application on Member Center;
  You need to provide following information:
  - 1) application description;
  - 2) APP_callback_URL;
  - 3) Revoke_URL
  3. Store private keys in safe way.
  Secret_key: key used to decrypt user information
  Credential: Used to generate digest information;
  4. Prepare encryption and decryption methods. We use AES-128-CBC algorithm. Read more on OpenSSL documents;
  5. Prepare MD5 digest method, the generated digest need to use hexadecimal form;
  6. Add method to handle callback action.
  - 1) verify sign;
  - 2) generate new sign;
  - 3) POST a request to Member Center.
  7. Modify login mechanism. When Member Center respond with user information, you need to
  - 1) verify sign;
  - 2) decryption user information
  - 3) login user based on current user information;

  8. Handle revoke action. When user changed password, Member Center will call revoke action to all third-party application to notify login information has been expired. You need to implement one method to
  - 1) verify revoking request is valid;
  - 2) logout corresponding user;

# Merits
  1. Reduce user's responsibility to keep many accounts;
  2. Reduce third-party application developing workload on user management;
  3. Providing better secure accounting service;
  4. Enable user's behavior analysis;
  5. Easy to manage user account, such as remove one terminated employees account from all internal services;
