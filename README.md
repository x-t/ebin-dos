# Ebin-DOS
The very functional operating system.

## Building
```
$ nasm -f bin -o ebin.img main.asm
```

## Testing
```
$ qemu-system-i386 -hda ebin.img
```

## Don't want to build it
The image is included, so no need.

## Hacking
The layout goes like this
```
%INTRO%

%PROMPT% %INPUT%
%PART1% %INPUT% %PART2%
%PROMPT%
```
You can change that by changing `intro`, `shell_ps`, `p1`, `p2` respectively.

## DOS?
It's an OS that runs from a hard drive, so, yes.

## License
ISC. See the [LICENSE](LICENSE) file.