[[ -v top ]] || top=$HOME/code

pysrc=${top}/pygemini
pybr=main
pyurl=https://github.com/gemini3d/pygemini
if [[ -d ${pysrc} ]]; then
  git -C ${pysrc} switch ${pybr}
  git -C ${pysrc} pull
else
  git -C ${top} clone ${pyurl} ${pysrc}
fi
python -m pip install -e ${pysrc}
