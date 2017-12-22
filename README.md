# Merits
  1. Reduce user's responsibility to keep many accounts;
  2. Reduce third-party application developing workload on user management;
  3. Providing better secure accounting service;
  4. Enable user's behavior analysis;
  5. Easy to manage user account, such as remove one terminated employees account from all internal services;
  
# achievement
  http://genius.internal.worksap.com
  
# API documentation
http://genius.internal.worksap.com/help

# Deployment
1. rails test
2. rails assets:precompile
3. bundle exec sidekiq
4. ensure localhost:redis
# To-do list
0. Mailer config TEST before deploy!
0.2 Add success solution;
1. PostgreSQL need to listen on limited addresses;
3. User link expire after used
4. Revoke login status after reset password or logout from genius center;
5. Security: Deviant user behavior alert
6. User behavior collecting and analysis
7. Classified authenticating level for different SP
8. Multi-location deployment
9. Read/write separation // Database replica
