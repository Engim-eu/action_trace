# frozen_string_literal: true

module ActionTrace
  class FetchActivityLogs
    include Interactor::Organizer

    organize ActionTrace::InitializeContext,
             ActionTrace::FetchDataChanges,
             ActionTrace::FetchPageVisits,
             ActionTrace::FetchSessionStarts,
             ActionTrace::MergeAndFormatResults
  end
end
