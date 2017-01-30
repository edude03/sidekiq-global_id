module Sidekiq
  module Middleware
    module Server
      class RetryJobs
        def call(worker, msg, queue)
          yield
        rescue Sidekiq::Shutdown
          # ignore, will be pushed back onto queue during hard_shutdown
          raise
        rescue Exception => e
          # ignore, will be pushed back onto queue during hard_shutdown
          raise Sidekiq::Shutdown if exception_caused_by_shutdown?(e)
          raise e unless msg['retry']

          # Reserialize the arguments
          msg['args'] = ActiveJob::Arguments.serialize(msg['args'])

          attempt_retry(worker, msg, queue, e)
        end
      end
    end
  end
end

module Sidekiq
  module GlobalId
    # Sidekiq client middleware deserializes arguments before
    # executing job.
    class ServerMiddleware
      # @param _worker [Sidekiq::Worker]
      # @param job [Hash] sidekiq job
      # @param _queue [String]
      # @return [<any>] job args
      def call(_worker, job, _queue)
        job['args'] = ActiveJob::Arguments.deserialize(job['args'])
        yield
      end
    end
  end
end
