<img width="150" height="150" align="left" style="float: left; margin: 0 10px 0 0;" alt="Ebin" src="https://raw.githubusercontent.com/x-t/ebin-dos/master/spurdo.png">

# Ebin-DOS
The very functional operating system\*.

\* Technically it's just a bootloader, there's no kernel, there's nothing really.

## Prerequisites
* nasm (building)
* qemu (testing)
* bochs (debugging)

## Building
```
$ nasm -f bin -o ebin.img main.asm
```

## Don't want to build it
The image is included, so no need.

## Testing
```
$ qemu-system-i386 -hda ebin.img
```
It's **not** a floppy image, even if it is 1.44 MB. The bootup procedure uses LBA, which requires a hard drive. ~~Fuck CHS.~~

However, if you do boot it up as a floppy, you'll get a very nice error message.

## Debugging
`bochsrc` is included, but to be honest there's nothing to debug. Also, the CHS numbers don't match. Just hit continue.

## Hacking
Read the source code. Don't consider this assembly learning material though, I barely know it myself.

## DOS?
~~It's an OS that runs from a hard drive, so, yes.~~

Technically it runs from a hard drive, it counts. It doesn't? Fuck you, I made the name.

## License
ISC. See the [LICENSE](LICENSE) file.
