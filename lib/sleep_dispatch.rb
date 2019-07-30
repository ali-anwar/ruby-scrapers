require 'securerandom'

class SleepDispatch

  class << self
    def call(seconds: 2)
      sleep(seconds + SecureRandom.random_number.round(4))

      yield
    end
  end

end
