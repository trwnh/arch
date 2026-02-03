#!/usr/bin/python

"""
Set SKIP_HOST_UPDATE to true in your discord settings.json

Discord sometimes sees an update and tells you "it's your lucky day",
but it asks you to download a .deb file. This doesn't work on Arch.

To keep Discord working (because it still *works* without the update),
we can set this option to have Discord start up without updating.
"""

import json

PATH = '~/.config/discord/settings.json'

with open(PATH) as settings_file:
	settings: dict = json.load(settings_file)

# If there is nothing to do, just exit.
if settings.get('SKIP_HOST_UPDATE', False):  # If it's missing, it defaults to false.
	exit()

# Otherwise, we write the setting to the file.
settings['SKIP_HOST_UPDATE'] = True
with open(PATH, 'w') as settings_file:
	json.dump(settings, settings_file, indent='\t', sort_keys=True)