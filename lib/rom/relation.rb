module ROM

  # Enhanced ROM relation wrapping axiom relation and using injected mapper to
  # load/dump tuples/objects
  #
  class Relation
    include Enumerable, Concord::Public.new(:relation, :mapper)

    alias_method :all, :to_a

    def each(&block)
      return to_enum unless block_given?
      relation.each { |tuple| yield(mapper.load(tuple)) }
      self
    end

    def insert(object)
      new(relation.insert([mapper.dump(object)]))
    end
    alias_method :<<, :insert

    def update(object)
      tuple = mapper.dump(object)
      new(relation.delete([tuple]).insert([ tuple ]))
    end

    def delete(object)
      new(relation.delete([mapper.dump(object)]))
    end

    def replace(objects)
      new(relation.replace(objects.map(&mapper.method(:dump))))
    end

    def restrict(*args, &block)
      new(relation.restrict(*args, &block))
    end

    def take(limit)
      new(sorted.take(limit))
    end

    def first(limit = 1)
      new(sorted.first(limit))
    end

    def last(limit = 1)
      new(sorted.last(limit))
    end

    def drop(offset)
      new(relation.drop(offset))
    end

    def order(*attributes)
      new(relation.sort_by { relation.header.project(attributes) })
    end

    def sort_by(*args, &block)
      new(relation.sort_by(*args, &block))
    end

    def ordered
      new(relation.sort_by(relation.header))
    end

    def inject_mapper(mapper)
      new(relation, mapper)
    end

    private

    def sorted
      relation.sort_by { relation.header }
    end

    def new(new_relation, new_mapper = mapper)
      self.class.new(new_relation, new_mapper)
    end

  end # class Relation

end # module ROM
