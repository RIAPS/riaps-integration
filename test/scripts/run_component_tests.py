import sys
import os
import subprocess
import argparse

sub_test_dirs = list()

def main():
	pycom_home = os.environ.get['PYCOM_TEST_HOME']
	if pycom_home is None:
		print ('Set PYCOM_TEST_HOME and try again.')
		return

	pycom_test_dir = os.path.join(pycom_home, 'example', 'tests')
	if not os.path.exists(pycom_test_dir):
		print (pycom_test_dir + ' does NOT exist.')
		return

	results_dir = os.environ.get['PYCOM_TEST_RESULTS']
	if results_dir is None:
		return


def get_directory_contents(parent_dir):
	for child in os.listdir(parent_dir):
		path = os.path.join(parent_dir, child)
		if os.path.isdir(path):
			if child == 'configs':
				zopkio_script = os.path.join(parent_dir, 'main_test.py')
				if os.path.exists(zopkio_script):
					#print("Parent Dir: \t" + parent_dir)
					#print("FOLDER: \t" + path)
					#print("Zopkio Script: \t" + zopkio_script)
					sub_test_dirs.append(parent_dir)
					return
			else:
				get_directory_contents(path)


def test_function(test_dir, results_dir):
	test_dir = os.path.join(test_dir, 'examples')

	if os.path.exists(test_dir):
		get_directory_contents(test_dir)

	if os.path.exists(results_dir):
		x = 2

	test_to_result_dir_map = dict()
	base_path_length = len(test_dir)
	#print (sub_test_dirs)
	for i in sub_test_dirs:
		result_sub_dir = i[base_path_length:]
		result_sub_dir = results_dir + result_sub_dir

		try:
			if not os.path.exists(result_sub_dir):
				os.makedirs(result_sub_dir)

			call_zopkio(os.path.join(i, 'main_test.py'), result_sub_dir)
		except Exception as e:
			print (str(e))

def call_zopkio(test_script_path, log_dir):
	zopkio = '/usr/local/bin/zopkio'
	try:
		if os.path.exists(test_script_path):
 			subprocess.call([zopkio, '--nopassword', test_script_path, '--output-dir', log_dir])
	except Exception as e:
		print (str(e))


if __name__ == "__main__":
    test_dir = ''
    results_dir = ''
    parser = argparse.ArgumentParser('Jenkins Zopkio Automation Script')
    parser.add_argument('-t', action='store')
    parser.add_argument('-r', action='store')

    try:
        args = parser.parse_args()
        if args.t is not None:
            test_dir = args.t
        if args.r is not None:
            results_dir = args.r
        test_function(test_dir, results_dir)
    except:
        print("Unexpected error:", sys.exc_info()[0])

