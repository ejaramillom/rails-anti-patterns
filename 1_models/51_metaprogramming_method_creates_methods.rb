# This define dynamically the instance role method for each const role
# @return [Boolean] with true/false if the role_name match
# @example CLIENT_CARE_COORDINATOR => client_care_coordinator?
Constants::UserRoles.constants.each do |constant_name|
  define_method "#{constant_name.downcase}?" do
    constant_value = Constants::UserRoles.const_get(constant_name)

    if constant_value.is_a?(Array)
      role_name.in?(constant_value)
    else
      role_name == constant_value
    end
  end
end
