module Sidekiq
  module GlobalId
    # Sidekiq client middleware serializes arguments before
    # pushing job to Redis.
    #
    class ClientMiddleware
      # @param _worker_class [Class<Sidekiq::Worker>]
      # @param job [Hash] sidekiq job
      # @param _queue [String]
      # @param _redis_pool [ConnectionPool]
      # @return [Hash] sidekiq job
      def call(_worker_class, job, _queue, _redis_pool)
        if (job['args'].all? { |arg| arg.is_a?(GlobalID) }) 
          yield
        else
          job['args'] = ActiveJob::Arguments.serialize(job['args'])
          yield
        end
      end
    end
  end
end
