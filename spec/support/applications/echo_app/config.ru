use Rack::Lint

run lambda { |env|
  obj = env.dup

  obj['kirk.sub_process?'] = Kirk.sub_process?

  if input = env['rack.input']
    obj['rack.input'] = input.read
  end

  if io = env['rack.errors']
    obj['rack.errors'] = true
  end

  [ 200, { 'Content-Type' => 'application/x-ruby-object' }, [ Marshal.dump(obj) ] ]
}
