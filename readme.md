# docker-42norminette

Based on the script and dump from [42_norminette](https://github.com/veroxy/42_norminette).
Some urls were dead :skull: and you have to figure out the dependencies by yourself.
Huge thanks to [veroxy](https://github.com/veroxy) and the mystery man make this bloated rubinius work :clap: 

**NO MERCY ! Run the official 42 norminette on any system without headache.**

## How to use ?

Pull the image

```bash
docker pull mrdotb/42norminette
# Will take some time image is 2go
```

Basic example

```bash
ls
ft_toupper.c Makefile ...
docker run -v $PWD:/temp --rm -it mrdotb/42norminette temp/ft_toupper.c
Norme: temp/srcs/ft_toupper.c
```

Unfortunately with the previous example you can't use glob, autocomplete, or relative path
I make a simple bash script to fix that.
Install it and put in in your local $PATH folder. I use `~/.local/bin` for that.

```bash
curl https://raw.githubusercontent.com/mrdotb/docker-42norminette/master/norminette > ~/.local/bin/norminette
chmod +x ~/.local/bin/norminette
rehash
# or restart your shell
# go crazy
norminette ../fdf/src/*.c
...
```

It's too slow for me :angry: 
Well the previous example create one temporary containers for each call we can speed up things but we loose flexibility.

```bash
pwd
/home/you/projects/libft
docker run --name libft -it --rm -d -v $PWD:/temp --entrypoint bash mrdotb/42norminette
docker exec -it libft ./norminette.sh /temp/$arg
# or in a bash script to get glob and friends
for arg in "$@"; do
  docker exec -it libft ./norminette.sh /temp/$arg
done
```


### Want to help ?

+ Give me :star:
+ Make the docker image lighter using alpine
+ A clever script faster and flexible
+ ?

:warning: Building the image take time since we have to compile llvm and rubinius
