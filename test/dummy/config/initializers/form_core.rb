FormCore.register_field_classes Fields::TextField,
                                Fields::IntegerField,
                                Fields::DecimalField,
                                Fields::BooleanField,
                                Fields::SelectField,
                                Fields::ResourceSelectField,
                                Fields::ResourceField,
                                Fields::VariableLengthNestedFormField

FormCore.register_data_source_classes DataSources::Empty,
                                      DataSources::Dictionary

FormCore.virtual_model_class = VirtualModel
