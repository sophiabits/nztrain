module AbilitySpecHelper
  User.send :define_method, 'should_be_permitted_to' do |actions,subjects|
    Array(actions).each do |action|
      Array(subjects).each do |subject|
        policy = subject.is_a?(Class) ? "#{subject.name}Policy" : "#{subject.class.name}Policy"
        expect(policy.constantize.new(self, subject).send("#{action}?")).to be true
      end
    end
  end

  User.send :define_method, 'should_not_be_permitted_to' do |actions,subjects|
    Array(actions).each do |action|
      Array(subjects).each do |subject|
        policy = subject.is_a?(Class) ? "#{subject.name}Policy" : "#{subject.class.name}Policy"
        expect(policy.constantize.new(self, subject).send("#{action}?")).to be false
      end
    end
  end
end
