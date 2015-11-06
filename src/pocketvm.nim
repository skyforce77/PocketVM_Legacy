include components.cpu, lib.compiler

proc runFile(file: string) =
  if fileExists(file):
    var cpu = CPU()
    cpu.load(file)
    cpu.start()
  else:
    echo "Could not run: file does not exists"

#Main
when isMainModule:
  include docopt

  const help = """
Usage:
  pocketvm [options] <file>
  pocketvm (-h | --help)
  pocketvm --version

Options:
  -c --compile      Compile a lisible pvm file to executable
  -h --help         Show this screen.
  -r --run          Run a pocketvm program
  --version         Show version.
"""

  let args = docopt(help, version="pocketvm 0.1")
  if args["<file>"]:
    var file: string = $args["<file>"]
    if args["--compile"]:
      var compiler = Compiler(filename:file)
      file = compiler.run()
      if not args["--run"]:
        quit(QuitSuccess)
    runFile(file);
  else:
    echo "error"
