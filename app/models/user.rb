class User < ApplicationRecord
  enum role: { ordinary: 0, admin: 1, inactive: 2, at_risk: 3, resigned: 4 }
end
