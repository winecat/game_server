# -*- coding: utf-8 -*- 
import time
import types
import os
import sys
import locale
import platform
import inspect
reload(sys)
sys.setdefaultencoding('utf-8') #IGNORE:E1101
locale.setlocale(locale.LC_ALL, "")


def gen_file(fname, data):
    '''
    生成文件
    @param module_name: 模板名称
    @param data: 数据，以list方式传入
    '''    
    #assert type(data) is types.ListType
    save_path = os.path.dirname(os.path.realpath(fname))
    if not os.path.exists(save_path):
        os.makedirs(save_path)
        
    open(fname, "w").write("".join(data))
    win2unix(fname)
    print("OK! {0} gen succeed! ".format(fname))


def parse_path(root_dir):
    sub_dir = ""
    listDirs = os.walk(root_dir) 
    for root, dirs, files in listDirs: 
        for d in dirs: 
            path = os.path.join(root, d)
            relative_path = path[len(root_dir)-3:]
            sub_dir += str(relative_path.replace("\\", "/"))
            sub_dir += ";"
    return sub_dir
            
def win2unix(fname):
    '''
    convert format file from windows to unix
    @param fname: the name of file
    @return: 0: Successfully!
            -1: This is Not a binary file.
             1: Don't convert this file.
    '''
    data = open(fname, "rb").read()
    if '\0' in data:
        return -1
    newdata = data.replace("\r\n", "\n")
    if newdata != data:
        open(fname, "wb").write(newdata)
        return 0
    return 1
    
    
## 此处修改检测的目录路径
input_dir = sys.argv[1]
## print input_dir
all_path = parse_path(input_dir)
## print all_path
path_data = """backend_version=17.0
eclipse.preferences.version=1
external_includes=
external_modules=
include_dirs=include;include/errcode;
output_dir=ebin
source_dirs=src;"""

path_data += all_path
gen_file("./.settings/org.erlide.core.prefs", path_data)

