include components.cpu, lib.compiler, lib.vmevents

proc runFile*(file: var string) =
  if fileExists(file):
    var pvmDir: string = getTempDir()&"pvm";
    var programDir: string = pvmDir&"/"&file.extractFilename();
    var code = programDir&"/code.bin";
    if not pvmDir.dirExists():
      pvmDir.createDir()
    if not programDir.dirExists():
      programDir.createDir()
    file.copyFile(code)
    file = code

    # Emit VM_EVENT_INIT
    var args = StatusEventArgs()
    args.status = 0;
    emitVmEvent(VM_INIT_EVENT, args)

    # Start CPU
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
  -c --compile           Compile a lisible pvm file to executable
  -h --help              Show this screen.
  -r --run               Run a pocketvm program
  -o --output=<to>       Define output filename
  --version              Show version.
"""

  let args = docopt(help, version="pocketvm 0.1")
  if args["<file>"]:
    var file: string = $args["<file>"]
    if args["--compile"]:
      var compiler: Compiler
      if args["--output"]:
        var to: string = $args["--output"]
        compiler = Compiler(filename: file, tomake: to)
      else:
        compiler = Compiler(filename: file)
      file = compiler.run()
      if not args["--run"]:
        quit(QuitSuccess)
    runFile(file);
  else:
    echo "error"
