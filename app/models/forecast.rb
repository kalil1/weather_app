class Forecast < ApplicationRecord

def cached?
  created_at > 30.minutes.ago ? false : true
end

end
