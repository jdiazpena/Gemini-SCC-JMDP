[[ -v top ]] || top=$HOME/code

exsrc=${top}/gemci
exbr=main
exurl=https://github.com/gemini3d/gemci
if [[ -d ${exsrc} ]]; then
  git -C ${exsrc} switch ${exbr}
  git -C ${exsrc} pull
else
  git -C ${top} clone ${exurl} ${exsrc}
fi
