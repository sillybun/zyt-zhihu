function! convert#ConvertToLatexMath()
    if has('python3')
python3 << EOF
import vim
import re
import sys

def zhihu_to_latex(math_code):
    math_code = re.sub(r"\\\\}", r"\\}", math_code)
    math_code = re.sub(r"\{align\}", r"{aligned}", math_code)
    math_code = math_code.strip()
    return math_code

total_line = vim.eval("line('.')")
buffer = vim.current.buffer
index = 0
while index < len(buffer):
    currentline = buffer[index]
    if not currentline.strip():
        index += 1
        continue
    while re.search(r'<img src="https://www.zhihu.com/equation\?tex=" alt="', currentline):
        ob = re.search(r'<img src="https://www.zhihu.com/equation\?tex=" alt="', currentline)
        if re.search(r'" eeimg="1">', currentline):
            ob_end = re.search(r'" eeimg="1">', currentline)
            if currentline[:ob_end.span()[0]].endswith("\\\\"):
                buffer[index] = currentline[0:ob.span()[0]] + "$$" + zhihu_to_latex(currentline[ob.span()[1]:ob_end.span()[0]-2]) + "$$" + currentline[ob_end.span()[1]:]
            else:
                buffer[index] = currentline[0:ob.span()[0]] + "$" + zhihu_to_latex(currentline[ob.span()[1]:ob_end.span()[0]]) + "$" + currentline[ob_end.span()[1]:]
        else:
            temp_index = index + 1
            while temp_index < len(buffer):
                t_line = buffer[temp_index]
                if not t_line.strip():
                    raise Exception("end symbol not found, start symbol location: %d" % index)
                if re.search(r'" eeimg="1">', t_line):
                    break
                temp_index += 1
            else:
                raise Exception("end symbol not found, start symbol location: %d" % index)
            ob_end = re.search(r'" eeimg="1">', t_line)
            if t_line[:ob_end.span()[0]].endswith("\\\\"):
                buffer[index] = currentline[0:ob.span()[0]] + "$$" + zhihu_to_latex(currentline[ob.span()[1]:])
                for i in range(index + 1, temp_index):
                    buffer[i] = zhihu_to_latex(buffer[i])
                buffer[temp_index] = zhihu_to_latex(t_line[0:ob_end.span()[0]-2]) + "$$" + t_line[ob_end.span()[1]:]
            else:
                buffer[index] = currentline[0:ob.span()[0]] + "$" + zhihu_to_latex(currentline[ob.span()[1]:])
                for i in range(index + 1, temp_index):
                    buffer[i] = zhihu_to_latex(buffer[i])
                buffer[temp_index] = zhihu_to_latex(t_line[0:ob_end.span()[0]]) + "$" + t_line[ob_end.span()[1]:]
        currentline = buffer[index]
    index += 1
EOF
    elseif has('python')
python << EOF
EOF
    endif
endfunction

function! convert#ConvertToZhihuMath()
    if has('python3')
python3 << EOF
import vim
import re
import sys

def latex_to_zhihu(math_code):
    math_code = math_code.strip()
    math_code = re.sub(r"\\}", r"\\\\}", math_code)
    return math_code

total_line = vim.eval("line('.')")
buffer = vim.current.buffer
index = 0
while index < len(buffer):
    currentline = buffer[index]
    if not currentline.strip():
        index += 1
        continue
    while re.search(r'\$', currentline):
        ob = re.search(r'\$', currentline)
        # print(currentline)
        # print(ob.span())
        if currentline[ob.span()[1]] == "$":
            if re.search(r'\$\$', currentline[ob.span()[1] + 1:]):
                ob_end = re.search(r'\$\$', currentline[ob.span()[1] + 1:])
                buffer[index] = currentline[0:ob.span()[0]] + '<img src="https://www.zhihu.com/equation?tex=" alt="' + latex_to_zhihu(currentline[ob.span()[1]+1:ob.span()[1] + 1 + ob_end.span()[0]]) + '\\\\" eeimg="1">' + currentline[ob.span()[1] + 1 + ob_end.span()[1]:]
            else:
                temp_index = index + 1
                while temp_index < len(buffer):
                    t_line = buffer[temp_index]
                    if not t_line.strip():
                        raise Exception("E116: end symbol not found, start symbol location: %d" % index)
                    if re.search(r'\$\$', t_line):
                        break
                    temp_index += 1
                else:
                    raise Exception("E121: end symbol not found, start symbol location: %d" % index)
                ob_end = re.search(r'\$\$', t_line)
                buffer[index] = currentline[0:ob.span()[0]] + '<img src="https://www.zhihu.com/equation?tex=" alt="' + latex_to_zhihu(currentline[ob.span()[1]+1:])
                for i in range(index + 1, temp_index):
                    buffer[index] = latex_to_zhihu(buffer[index])
                buffer[temp_index] = latex_to_zhihu(t_line[0:ob_end.span()[0]]) + '\\\\" eeimg="1">' + t_line[ob_end.span()[1]:]
        else:
            if re.search(r'\$', currentline[ob.span()[1]:]):
                ob_end = re.search(r'\$', currentline[ob.span()[1]:])
                buffer[index] = currentline[0:ob.span()[0]] + '<img src="https://www.zhihu.com/equation?tex=" alt="' + latex_to_zhihu(currentline[ob.span()[1]:ob.span()[1] + ob_end.span()[0]]) + '" eeimg="1">' + currentline[ob.span()[1] + ob_end.span()[1]:]
            else:
                temp_index = index + 1
                while temp_index < len(buffer):
                    t_line = buffer[temp_index]
                    if not t_line.strip():
                        raise Exception("E134: end symbol not found, start symbol location: %d" % index)
                    if re.search(r'\$', t_line):
                        break
                    temp_index += 1
                else:
                    raise Exception("E139 end symbol not found, start symbol location: %d" % index)
                ob_end = re.search(r'\$', t_line)
                buffer[index] = currentline[0:ob.span()[0]] + '<img src="https://www.zhihu.com/equation?tex=" alt="' + latex_to_zhihu(currentline[ob.span()[1]:])
                for i in range(index + 1, temp_index):
                    buffer[index] = latex_to_zhihu(buffer[index])
                buffer[temp_index] = latex_to_zhihu(t_line[0:ob_end.span()[0]]) + '" eeimg="1">' + t_line[ob_end.span()[1]:]
        currentline = buffer[index]
    index += 1
EOF
    elseif has('python')
python << EOF
EOF
    endif
endfunction
