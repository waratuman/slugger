module Slugger
  module ActiveRecordRelationSluggerExtension

    def find_one(id)
      friendly = id.respond_to?(:to_i) && id.to_i.to_s != id.to_s
      friendly ? find_by_slug!(id) : super
    end

    def find_some(ids)
      friendly = -> (id) { id.respond_to?(:to_i) && id.to_i.to_s != id.to_s }
      return super if !ids.all? { |x| friendly.call(x) }

      result = where(table['slug'].in(ids)).to_a

      expected_size =
      if limit_value && ids.size > limit_value
        limit_value
      else
        ids.size
      end

      # 11 ids with limit 3, offset 9 should give 2 results.
      if offset_value && (ids.size - offset_value < expected_size)
        expected_size = ids.size - offset_value
      end

      if result.size == expected_size
        result
      else
        raise_record_not_found_exception!(ids, result.size, expected_size)
      end
    end

  end
end
