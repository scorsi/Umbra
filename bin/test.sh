#!/usr/bin/env bash

echo "----------------------------------------------------------"
echo "Ensuring Elixir is installed..."
echo "----------------------------------------------------------"
command -v elixir >/dev/null 2>&1 || {
  echo "This app requires Elixir, but it was not found on your system."
  echo "Install it using the instructions at http://elixir-lang.org"
  exit 1
}
echo "Done!"

echo "----------------------------------------------------------"
echo "Ensuring Hex is installed..."
echo "----------------------------------------------------------"
mix local.hex --force
mix local.rebar --force
echo "Done!"

echo "----------------------------------------------------------"
echo "Installing Mix dependencies..."
echo "----------------------------------------------------------"
mix deps.get || { echo "Mix dependencies could not be installed!"; exit 1; }

echo "----------------------------------------------------------"
echo "Running Tests..."
echo "----------------------------------------------------------"

MIX_ENV="dev" mix compile --warnings-as-errors --force || { echo 'Please fix all compiler warnings.'; exit 1; }
MIX_ENV="test" mix credo --strict || { echo 'Elixir code failed Credo linting. See warnings above.'; exit 1; }
MIX_ENV="test" mix docs || { echo 'Elixir HTML docs were not generated!'; exit 1; }
MIX_ENV="test" mix test || { echo 'Elixir tests failed!'; exit 1; }

if [ "$CI" ]; then
  if [ "$TRAVIS" ]; then
    echo "----------------------------------------------------------"
    echo "Running coveralls.travis..."
    echo "----------------------------------------------------------"
    MIX_ENV="test" mix coveralls.travis || { echo 'Elixir coverage on Umbra failed!'; exit 1; }
  else
    echo "----------------------------------------------------------"
    echo "Running coveralls..."
    echo "----------------------------------------------------------"
    MIX_ENV="test"mix coveralls || { echo 'Elixir coverage on Umbra failed!'; exit 1; }
  fi
fi
echo "Done!"