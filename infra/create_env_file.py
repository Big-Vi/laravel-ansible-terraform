import boto3

ssm_client = boto3.client('ssm', region_name='ap-southeast-2')

parameter_names = ['laravel_APP_DEBUG', 'laravel_APP_ENV', 'laravel_APP_KEY', 'laravel_APP_LOCALE_PHP',
                   'laravel_APP_NAME', 'laravel_APP_TIMEZONE', 'laravel_DB_USERNAME', 'laravel_DB_PORT',
                   'laravel_DB_PASSWORD', 'laravel_DB_CONNECTION', 'laravel_DB_DATABASE']

# Create .env file
with open('.env', 'w') as env_file:
    for param_name in parameter_names:
        response = ssm_client.get_parameter(
            Name=param_name, WithDecryption=True)
        param_value = response['Parameter']['Value']
        param_name_trimmed = param_name.replace("laravel_", "")
        env_file.write(f'{param_name_trimmed}={param_value}\n')
