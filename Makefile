coveralls:
	MIX_ENV=test mix coveralls

services: stop-services
	docker-compose up -d

stop-services:
	docker-compose down

force-compile:
	mix compile --force --warnings-as-errors

clean:
	mix deps.clean --unlock --unused

deep-clean:
	rm -rf _build
	rm -rf deps

setup: services
	cd assets | npm install
	mix setup

format:
	mix format --check-formatted || mix format

force-format:
	find test -name '*.ex' -o -name '*.exs' | mix format --check-formatted || mix format
	find lib -name '*.ex' -o -name '*.exs' | mix format --check-formatted || mix format

gcdeps:
	mix deps.clean --all && mix deps.get && mix deps.compile

dev: services
	iex -S mix phx.server

credo:
	mix credo --strict

dialyzer:
	MIX_DEBUG=1 mix dialyzer --ignore-exit-status --cache=false

sobelow:
	mix sobelow

check-docs:
	mix doctor --raise

dump:
	mix ecto.dump

dev-console:
	MIX_ENV=dev iex -S mix

test-console:
	MIX_ENV=test iex -S mix

delete-compiled-statics:
	mix phx.digest.clean --all

install-dep-tools:
	mix do local.hex --if-missing --force, local.rebar --if-missing --force

deploy:
	fly deploy --ha=false --no-cache -a mejora
