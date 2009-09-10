module WithoutScope
  module ActsAsRevisable
    
    # This module is mixed into the revision classes.
    # 
    # ==== Callbacks
    # 
    # * +before_revise+ is called before the record is revised.
    # * +after_revise+ is called after the record is revised.
    # * +before_revert+ is called before the record is reverted.
    # * +after_revert+ is called after the record is reverted.
    # * +before_changeset+ is called before a changeset block is called.
    # * +after_changeset+ is called after a changeset block is called.
    # * +after_branch_created+ is called on the new revisable instance
    #   created by branching after it's been created.
    module Revisable
      def self.included(base) #:nodoc:
        base.send(:extend, ClassMethods)
                
        class << base
          attr_accessor :revisable_revision_class, :revisable_columns
        end
        
        base.class_inheritable_hash :revisable_shared_objects
        base.revisable_shared_objects = {}
        
        base.instance_eval do
          attr_accessor :revisable_new_params, :revisable_revision
          
          define_callbacks :before_revise, :after_revise, :before_revert, :after_revert, :before_changeset, :after_changeset, :after_branch_created
                    
          before_create :before_revisable_create
          before_update :before_revisable_update
          after_update :after_revisable_update
          after_save :clear_revisable_shared_objects!, :unless => :is_reverting?
          
          default_scope :conditions => {:revisable_is_current => true}
          
          [:revisions, revisions_association_name.to_sym].each do |assoc|
            has_many assoc, (revisable_options.revision_association_options || {}).merge({:class_name => revision_class_name, :foreign_key => :revisable_original_id, :order => "#{quoted_table_name}.#{connection.quote_column_name(:revisable_number)} DESC", :dependent => :destroy})
          end
        end

        if !Object.const_defined?(base.revision_class_name) && base.revisable_options.generate_revision_class?
          Object.const_set(base.revision_class_name, Class.new(ActiveRecord::Base)).instance_eval do
            acts_as_revision
          end
        end
      end
      
      # Finds a specific revision of self.
      # 
      # The +by+ parameter can be a revision_class instance, 
      # the symbols :first, :previous or :last, a Time instance
      # or an Integer.
      # 
      # When passed a revision_class instance, this method
      # simply returns it. This is used primarily by revert_to!.
      # 
      # When passed :first it returns the first revision created.
      # 
      # When passed :previous or :last it returns the last revision
      # created.
      # 
      # When passed a Time instance it returns the revision that
      # was the current record at the given time.
      # 
      # When passed an Integer it returns the revision with that
      # revision_number.
      def find_revision(by)
        by = Integer(by) if by.is_a?(String) && by.match(/[0-9]+/)
          
        case by
        when self.class
          by
        when self.class.revision_class
          by
        when :first
          revisions.last
        when :previous, :last
          revisions.first
        when Time
          revisions.find(:first, :conditions => ["? >= ? and ? <= ?", :revisable_revised_at, by, :revisable_current_at, by])
        when self.revisable_number
          self
        else
          revisions.find_by_revisable_number(by)
        end
      end
            
      # Returns a revisable_class instance initialized with the record
      # found using find_revision.
      # 
      # The +what+ parameter is simply passed to find_revision and the
      # returned record forms the basis of the reverted record.
      # 
      # ==== Callbacks
      # 
      # * +before_revert+ is called before the record is reverted.
      # * +after_revert+ is called after the record is reverted.
      # 
      # If :without_revision => true has not been passed the 
      # following callbacks are also called:
      # 
      # * +before_revise+ is called before the record is revised.
      # * +after_revise+ is called after the record is revised.
      def revert_to(what, *args, &block) #:yields:
        is_reverting!
        
        unless run_callbacks(:before_revert) { |r, o| r == false}
          raise ActiveRecord::RecordNotSaved
        end
      
        options = args.extract_options!
    
        rev = find_revision(what)
        self.reverting_to, self.reverting_from = rev, self
        
        unless rev.run_callbacks(:before_restore) { |r, o| r == false}
          raise ActiveRecord::RecordNotSaved
        end
    
        self.class.column_names.each do |col|
          next unless self.class.revisable_should_clone_column? col
          self[col] = rev[col]
        end
    
        self.no_revision! if options.delete :without_revision
        self.revisable_new_params = options
        
        yield(self) if block_given?
        rev.run_callbacks(:after_restore)
        run_callbacks(:after_revert)
        self
      ensure
        is_reverting!(false)
        clear_revisable_shared_objects!
      end
    
      # Same as revert_to except it also saves the record.
      def revert_to!(what, *args)
        revert_to(what, *args) do
          self.no_revision? ? save! : revise!
        end
      end
      
      # Equivalent to:
      #   revert_to(:without_revision => true)
      def revert_to_without_revision(*args)
        options = args.extract_options!
        options.update({:without_revision => true})
        revert_to(*(args << options))
      end
      
      # Equivalent to:
      #   revert_to!(:without_revision => true)
      def revert_to_without_revision!(*args)
        options = args.extract_options!
        options.update({:without_revision => true})
        revert_to!(*(args << options))
      end
      
      # Globally sets the reverting state of this record.
      def is_reverting!(val=true) #:nodoc:
        set_revisable_state(:reverting, val)
      end
      
      # Returns true if the _record_ (not just this instance 
      # of the record) is currently being reverted.
      def is_reverting?
        get_revisable_state(:reverting) || false
      end
      
      # Sets whether or not to force a revision.
      def force_revision!(val=true) #:nodoc:
        set_revisable_state(:force_revision, val)
      end
      
      # Returns true if a revision should be forced.
      def force_revision? #:nodoc:
        get_revisable_state(:force_revision) || false
      end
      
      # Sets whether or not a revision should be created.
      def no_revision!(val=true) #:nodoc:
        set_revisable_state(:no_revision, val)
      end
      
      # Returns true if no revision should be created.
      def no_revision? #:nodoc:
        get_revisable_state(:no_revision) || false
      end
            
      # Force an immediate revision whether or
      # not any columns have been modified.
      # 
      # The +args+ catch-all argument is not used. It's primarily
      # there to allow +revise!+ to be used directly as an association
      # callback since association callbacks are passed an argument.
      # 
      # ==== Callbacks
      # 
      # * +before_revise+ is called before the record is revised.
      # * +after_revise+ is called after the record is revised.
      def revise!(*args)
        return if in_revision?
        
        begin
          force_revision!
          in_revision!
          save!
        ensure
          in_revision!(false)
          force_revision!(false)
        end
      end
            
      # Groups statements that could trigger several revisions into
      # a single revision. The revision is created once #save is called.
      # 
      # ==== Example
      # 
      #   @project.revision_number # => 1
      #   @project.changeset do |project|
      #     # each one of the following statements would 
      #     # normally trigger a revision
      #     project.update_attribute(:name, "new name")
      #     project.revise!
      #     project.revise!
      #   end
      #   @project.save
      #   @project.revision_number # => 2
      # 
      # ==== Callbacks
      # 
      # * +before_changeset+ is called before a changeset block is called.
      # * +after_changeset+ is called after a changeset block is called.      
      def changeset(&block)
        return unless block_given?
        
        return yield(self) if in_revision?
        
        unless run_callbacks(:before_changeset) { |r, o| r == false}
          raise ActiveRecord::RecordNotSaved
        end
        
        begin
          force_revision!
          in_revision!
        
          returning(yield(self)) do
            run_callbacks(:after_changeset)
          end
        ensure
          in_revision!(false)       
        end
      end
      
      # Same as +changeset+ except it also saves the record.
      def changeset!(&block)
        changeset do
          block.call(self)
          save!
        end
      end
      
      def without_revisions!
        return if in_revision? || !block_given?
        
        begin
          no_revision!
          in_revision!
          yield
          save!
        ensure
          in_revision!(false)
          no_revision!(false)
        end
      end
      
      # acts_as_revisable's override for ActiveRecord::Base's #save!
      def save!(*args) #:nodoc:
        self.revisable_new_params ||= args.extract_options!
        self.no_revision! if self.revisable_new_params.delete :without_revision
        super
      end
      
      # acts_as_revisable's override for ActiveRecord::Base's #save  
      def save(*args) #:nodoc:
        self.revisable_new_params ||= args.extract_options!
        self.no_revision! if self.revisable_new_params.delete :without_revision
        super(args)
      end
      
      # Set some defaults for a newly created +Revisable+ instance.
      def before_revisable_create #:nodoc:
        self[:revisable_is_current] = true
        self.revision_number ||= 0
      end
      
      # Checks whether or not a +Revisable+ should be revised.
      def should_revise? #:nodoc:
        return false if new_record?
        return true if force_revision?
        return false if no_revision?
        return false unless self.changed?
        !(self.changed.map(&:downcase) & self.class.revisable_watch_columns).blank?
      end
      
      # Checks whether or not a revision should be stored.
      # If it should be, it initialized the revision_class
      # and stores it in an accessor for later saving.
      def before_revisable_update #:nodoc:
        return unless should_revise?
        in_revision!
        
        unless run_callbacks(:before_revise) { |r, o| r == false}
          in_revision!(false)
          return false
        end
        
        self.revisable_revision = self.to_revision
      end
      
      # Checks if an initialized revision_class has been stored
      # in the accessor. If it has been, this instance is saved.
      def after_revisable_update #:nodoc:
        if no_revision? # check and see if no_revision! was called in a callback 
          self.revisable_revision = nil
          return true
        elsif self.revisable_revision
          self.revisable_revision.save
          revisions.reload
          run_callbacks(:after_revise)
        end
        in_revision!(false)
        force_revision!(false)
        true
      end
      
      # Returns true if the _record_ (not just this instance 
      # of the record) is currently being revised.
      def in_revision?
        get_revisable_state(:revision)
      end

      # Manages the internal state of a +Revisable+ controlling 
      # whether or not a record is being revised. This works across
      # instances and is keyed on primary_key.
      def in_revision!(val=true) #:nodoc:
        set_revisable_state(:revision, val)
      end
            
      # This returns a new +Revision+ instance with all the appropriate
      # values initialized.
      def to_revision #:nodoc:
        rev = self.class.revision_class.new(self.revisable_new_params)

        rev.revisable_original_id = self.id
        
        new_revision_number = revisions.maximum(:revisable_number) + 1 rescue self.revision_number
        rev.revision_number = new_revision_number
        self.revision_number = new_revision_number + 1
        
        self.class.column_names.each do |col|
          next unless self.class.revisable_should_clone_column? col
          val = self.send("#{col}_changed?") ? self.send("#{col}_was") : self.send(col)
          rev.send("#{col}=", val)
        end

        self.revisable_new_params = nil

        rev
      end
      
      # This returns
      def current_revision
        self
      end
      
      def for_revision
        key = self.read_attribute(self.class.primary_key)
        self.class.revisable_shared_objects[key] ||= {}
      end
      
      def reverting_to
        for_revision[:reverting_to]
      end
      
      def reverting_to=(val)
        for_revision[:reverting_to] = val
      end
      
      def reverting_from
        for_revision[:reverting_from]
      end
      
      def reverting_from=(val)
        for_revision[:reverting_from] = val
      end

      def clear_revisable_shared_objects!
        key = self.read_attribute(self.class.primary_key)
        self.class.revisable_shared_objects.delete(key)
      end
            
      module ClassMethods
        # acts_as_revisable's override for with_scope that allows for
        # including revisions in the scope.
        # 
        # ==== Example
        # 
        #   with_scope(:with_revisions => true) do
        #     ...
        #   end
        def with_scope(*args, &block) #:nodoc:
          options = (args.grep(Hash).first || {})[:find]

          if options && options.delete(:with_revisions)
            with_exclusive_scope do
              super(*args, &block)
            end
          else
            super(*args, &block)
          end
        end
        
        # acts_as_revisable's override for find that allows for
        # including revisions in the find.
        # 
        # ==== Example
        # 
        #   find(:all, :with_revisions => true)
        def find(*args) #:nodoc:
          options = args.grep(Hash).first
        
          if options && options.delete(:with_revisions)
            with_exclusive_scope do
              super(*args)
            end
          else
            super(*args)
          end
        end
              
        # Returns the +revision_class_name+ as configured in
        # +acts_as_revisable+.
        def revision_class_name #:nodoc:
          self.revisable_options.revision_class_name || "#{self.name}Revision"
        end
      
        # Returns the actual +Revision+ class based on the 
        # #revision_class_name.
        def revision_class #:nodoc:
          self.revisable_revision_class ||= self.revision_class_name.constantize
        end
        
        # Returns the revisable_class which in this case is simply +self+.
        def revisable_class #:nodoc:
          self
        end
        
        # Returns the name of the association acts_as_revisable
        # creates.
        def revisions_association_name #:nodoc:
          revision_class_name.pluralize.underscore
        end
        
        # Returns an Array of the columns that are watched for changes.
        def revisable_watch_columns #:nodoc:
          return self.revisable_columns unless self.revisable_columns.blank?
          return self.revisable_columns ||= [] if self.revisable_options.except == :all
          return self.revisable_columns ||= [self.revisable_options.only].flatten.map(&:to_s).map(&:downcase) unless self.revisable_options.only.blank?
                    
          except = [self.revisable_options.except].flatten || []
          except += REVISABLE_SYSTEM_COLUMNS
          except += REVISABLE_UNREVISABLE_COLUMNS
          except.uniq!

          self.revisable_columns ||= (column_names - except.map(&:to_s)).flatten.map(&:downcase)
        end
      end
    end
  end
end