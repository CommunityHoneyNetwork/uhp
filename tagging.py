import os
import json
import argparse


def parse_config(fname):
    try:
        config = open(fname, 'r').read()
        config_dict = json.loads(config)
        return config_dict
    except:
        return None


def write_config(fname, config_dict):
    try:
        config_file = open(fname, 'w')
        json_str = json.dumps(config_dict)
        config_file.write(json_str)
        config_file.flush()
        config_file.close()
    except:
        return


def main():
    aparser = argparse.ArgumentParser()
    aparser.add_argument("-d", "--directory",
                         default="/opt/uhp/configs/",
                         help="UHP JSON config directory")
    aparser.add_argument("-t", "--tags",
                         help="Comma separated tag string")
    args = aparser.parse_args()

    try:
        tags = [tag.strip() for tag in args.tags.split(',')]
    except Exception as e:
        tags = []

    for fname in os.listdir(args.directory):
        if fname.endswith(".json"):
            config_dict = parse_config(args.directory + "/" + fname)
            try:
                config_dict["tags"] = list(set(config_dict["tags"] + tags))
            except:
                config_dict["tags"] = tags
            write_config(args.directory + "/" + fname, config_dict)
    return 0


if __name__ == "__main__":
    main()
