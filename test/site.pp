hiera_include('classes')

# resource wrapper
$files=hiera_hash('files', {})
create_resources(file, $files)

$crons=hiera_hash('crons', {})
create_resources(cron, $crons)

$execs=hiera_hash('execs', {})
create_resources(exec, $execs)

$hosts=hiera_hash('hosts', {})
create_resources(host, $hosts)

$mounts=hiera_hash('mounts', {})
create_resources(mount, $mounts)

$packages=hiera_hash('packages', {})
create_resources(package, $packages)

$services=hiera_hash('services', {})
create_resources(service, $services)
