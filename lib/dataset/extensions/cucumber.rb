$__dataset_top_level = self
module Dataset
  module Extensions # :nodoc:

    module CucumberWorld # :nodoc:
      def dataset(*datasets, &block)
        add_dataset(*datasets, &block)

        load = nil
        level = $__cucumber_toplevel || $__dataset_top_level
        level.send(:Before) do
          load = dataset_session.load_datasets_for(self.class)
          extend_from_dataset_load(load)
        end
        # Makes sure the datasets are reloaded after each scenario
        if Cucumber::Rails.respond_to?(:use_transactional_fixtures)
          Cucumber::Rails.use_transactional_fixtures
        else
          self.use_transactional_fixtures = true
        end
      end
    end

  end
end
Cucumber::Rails::World.extend Dataset::Extensions::CucumberWorld