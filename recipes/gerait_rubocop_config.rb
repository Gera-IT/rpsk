copy_file("#{ Dir.pwd }/.rubocop.yml", "#{ destination_root }/.rubocop.yml")

if prefer(:git, true)
  git(:add => '.rubocop.yml')
  git(:commit => '-qm "rails_apps_composer: added .rubocop.yml"')
end

__END__

name: gerait_rubocop_config
description: "Adds Gera's .rubocop.yml"
author: kryachkov.andrey@gmail.com

category: other
requires: []
run_after: [extras, gems, init]
