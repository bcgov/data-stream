import os

from setuptools import setup, find_packages
from setuptools.command.test import test as TestCommand


def read(filename):
    file_path = os.path.join(os.path.dirname(__file__), filename)
    return open(file_path).read()

class PyTest(TestCommand):
    user_options = [("pytest-args=", "a", "Arguments to pass to pytest")]

    def initialize_options(self):
        TestCommand.initialize_options(self)
        self.pytest_args = ""

    def run_tests(self):
        import shlex

        # import here, cause outside the eggs aren't loaded
        import pytest

        errno = pytest.main(shlex.split(self.pytest_args))
        sys.exit(errno)

setup(
    name='DataStream Api',
    author='Brandon Sharratt',
    author_email='',
    version='0.1',
    description="Data-Stream Api",
    long_description=read('README.md'),
    license='Apache 2.0',

    packages=find_packages(),
    include_package_data=True,
    install_requires=[
        'flask',
        'flask-compress',
        'gevent',
        'pyyaml',
        'requests',
        'mongoengine'
    ],
    setup_requires=[
    ],
    tests_require=[
        'pytest',
        'pytest-cov',
        'pytest-mock',
        'mongomock',
    ],
    cmdclass={"pytest": PyTest},
)
