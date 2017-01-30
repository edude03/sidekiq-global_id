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
        begin
          yield
        rescue Exception => e
          # put the args back how they were
          job['args'] = ActiveJob::Arguments.serialize(job['args'])
        end
      end
    end
  end
end
