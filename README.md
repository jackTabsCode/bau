# bulk-animation-upload

I made this quick and dirty tool to upload Roblox animations from a Model. I got tired of doing it manually.

## Usage
- Create your animations in Roblox Studio.
- In your animation rig, you should have a file called `AnimSaves` with all of your `KeyframeSequence`(s). Save this to a file.
- Download the executable (or build it yourself with `lune build`).
- Run it and pass it your input file.
- The results will be outputted to `output.txt`.

## Example
```bash
./bulk-animation-upload input.rbxm
```

## Arguments
`--group, -g` `<number>` The group ID to upload to

`--verbose, -v` Enable verbose logging
