include components.cpu

when isMainModule:
  include docopt

  const help = """
Usage:
  pocketvm <file>
  pocketvm (-h | --help)
  pocketvm --version

Options:
  -h --help         Show this screen.
  --version         Show version.
"""

  let args = docopt(help, version="pocketvm 0.1")
  if args["<file>"]:
    if fileExists($args["<file>"]):
      let cpu = CPU()
      cpu.load($args["<file>"])
      cpu.start()
    else:
      echo "file does not exists"
  else:
    echo "error"
