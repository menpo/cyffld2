import os


def src_dir_path():
    r"""The path to the top of the cyffld2 Python package.
    Useful for locating where the models folder is stored.

    Returns
    -------
    path : str
        The full path to the top of the cyffld2 package
    """
    return os.path.split(os.path.abspath(__file__))[0]


def models_dir_path():
    r"""The path to the models directory of the cyffld2 Python package.

    Returns
    -------
    path : str
        The full path to the models directory of the cyffld2 package
    """
    return os.path.join(src_dir_path(), 'ffld2', 'models')
