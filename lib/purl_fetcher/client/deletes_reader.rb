class PurlFetcher::Client::DeletesReader < PurlFetcher::Client::Reader
  # Enumerate objects that should be deleted.
  def each
    return to_enum(:each) unless block_given?

    deletes(first_modified: first_modified).each do |change|

      public_xml = PurlFetcher::Client::PublicXmlRecord.new(change['druid'].sub('druid:', ''), settings)

      yield public_xml, change, self
    end

    changes(first_modified: first_modified, target: target).each do |change|
      public_xml = PurlFetcher::Client::PublicXmlRecord.new(change['druid'].sub('druid:', ''), settings)

      next unless target.nil? || (change['false_targets'] && change['false_targets'].include?(target)) || (settings['skip_if_catkey'] && record.catkey)

      yield public_xml, change, self
    end
  end
end
