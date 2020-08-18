#!/usr/bin/env rspec
# frozen_string_literal: true

require './parser.rb'

describe Parser do
  describe 'with invalid log file' do
    context 'when not provided' do
      before { ARGV.replace [''] }

      it 'should return error' do
        expect { described_class.new.parse }
          .to output(a_string_including('Incorrect file name or file does not exist.'))
          .to_stdout_from_any_process
      end
    end

    context 'when wrong file name provided' do
      before { ARGV.replace ['invalid_filename'] }

      it 'should return error' do
        expect { described_class.new.parse }
          .to output(a_string_including('Incorrect file name or file does not exist.'))
          .to_stdout_from_any_process
      end
    end

    context 'when file is empty' do
      before { ARGV.replace ['spec/webserver_empty.log'] }

      it 'should return error' do
        expect { described_class.new.parse }
          .to output(a_string_including('Log file is empty.'))
          .to_stdout_from_any_process
      end
    end
  end

  describe 'with valid log file' do
    context 'when provided' do
      before { ARGV.replace ['spec/webserver.log'] }

      it 'should return parsed log' do
        expectation = expect { described_class.new.parse }
        expectation.to output(a_string_including('Visits:')).to_stdout_from_any_process
        expectation.to output(a_string_including('/pages/1 2 visits')).to_stdout_from_any_process
        expectation.to output(a_string_including('/pages/3 2 visits')).to_stdout_from_any_process
        expectation.to output(a_string_including('/about 1 visit')).to_stdout_from_any_process
        expectation.to output(a_string_including('/pages/2 1 visit')).to_stdout_from_any_process
        expectation.to output(a_string_including('Unique views:')).to_stdout_from_any_process
        expectation.to output(a_string_including('/pages/1 2 unique views')).to_stdout_from_any_process
        expectation.to output(a_string_including('/pages/3 2 unique views')).to_stdout_from_any_process
        expectation.to output(a_string_including('/about 1 unique view')).to_stdout_from_any_process
        expectation.to output(a_string_including('/pages/2 1 unique view')).to_stdout_from_any_process
      end
    end
  end

  describe '#read_file' do
    context 'when file exists' do
      before { ARGV.replace ['spec/webserver.log'] }

      it 'should not assing error and return file' do
        subject.read_file

        expect(subject.errors).to be_empty
        expect(subject.file).to be_kind_of(File)
      end
    end

    context 'when file does not exists' do
      before { ARGV.replace ['invalid_filename'] }

      it 'should assign error' do
        subject.read_file

        expect(subject.errors).to include('Incorrect file name or file does not exist.')
      end
    end
  end

  describe '#initiate_logs' do
    context 'when file content is valid' do
      before { ARGV.replace ['spec/webserver.log'] }

      it 'should assign logs' do
        subject.read_file
        subject.initiate_logs

        expect(subject.logs).to eq(
          [
            ['/pages/1', ['126.318.035.038', '126.318.035.037']],
            ['/pages/3', ['126.318.035.035', '126.318.035.036']],
            ['/about', ['126.318.035.037']],
            ['/pages/2', ['126.318.035.035']]
          ]
        )
      end
    end

    context 'when file content is empty' do
      before { ARGV.replace ['spec/webserver_empty.log'] }

      it 'should not assign logs' do
        subject.read_file
        subject.initiate_logs

        expect(subject.logs).to eq([])
        expect(subject.errors).to include('Log file is empty.')
      end
    end
  end

  describe '#parse initiated logs' do
    shared_examples 'should return logs with views count' do
      it 'should return logs with views count' do
        expectation = expect { subject.parse_views }
        expectation.to output(a_string_including('Visits:')).to_stdout_from_any_process
        expectation.to output(a_string_including('/pages/1 2 visits')).to_stdout_from_any_process
        expectation.to output(a_string_including('/pages/3 2 visits')).to_stdout_from_any_process
        expectation.to output(a_string_including('/about 1 visit')).to_stdout_from_any_process
        expectation.to output(a_string_including('/pages/2 1 visit')).to_stdout_from_any_process
      end
    end

    shared_examples 'should return logs with unique views count' do
      it 'should return logs with unique views count' do
        expectation = expect { subject.parse_unique_views }
        expectation.to output(a_string_including('Unique views:')).to_stdout_from_any_process
        expectation.to output(a_string_including('/pages/1 2 unique views')).to_stdout_from_any_process
        expectation.to output(a_string_including('/pages/3 2 unique views')).to_stdout_from_any_process
        expectation.to output(a_string_including('/about 1 unique view')).to_stdout_from_any_process
        expectation.to output(a_string_including('/pages/2 1 unique view')).to_stdout_from_any_process
      end
    end

    before { ARGV.replace ['spec/webserver.log'] }

    before(:each) do
      subject.read_file
      subject.initiate_logs
    end

    describe 'parse views' do
      include_examples 'should return logs with views count'
    end

    describe 'parse unique views' do
      include_examples 'should return logs with unique views count'
    end

    describe 'parse logs' do
      include_examples 'should return logs with views count'
      include_examples 'should return logs with unique views count'
    end
  end
end
