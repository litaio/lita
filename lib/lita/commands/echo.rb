module Lita
  module Commands
    class Echo < Command
      command "echo"

      description "Echoes back whatever you write."

      def call
        say message.args.join(" ")
      end
    end
  end
end
