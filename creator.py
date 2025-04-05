# create_flutter_folders.py
import os

# Define the base directory (where the 'lib' folder will be created)
# Leave as "" to create in the same directory as the script
# Or specify a path like "/path/to/your/project"
base_dir = ""

# List of all directories to create, relative to the base_dir
# We include the parent directories as well to ensure the structure
# is created correctly by os.makedirs
folders = [
    "lib",
    "lib/core",
    "lib/core/constants",
    "lib/core/themes",
    "lib/presentation",
    "lib/presentation/screens",
    "lib/presentation/widgets",
    "lib/presentation/blocs",
    "lib/domain",
    "lib/domain/models",
    "lib/domain/repositories",
    "lib/domain/usecases",
    "lib/data",
    "lib/data/repositories",
    "lib/data/datasources",
]

print("Starting folder creation...")

# Loop through the list of folders
for folder_path in folders:
    # Construct the full path
    full_path = os.path.join(base_dir, folder_path)

    try:
        # Create the directory including any necessary parent directories.
        # exist_ok=True prevents an error if the directory already exists.
        os.makedirs(full_path, exist_ok=True)
        print(f"Successfully created or verified: {full_path}")
    except OSError as e:
        print(f"Error creating directory {full_path}: {e}")

print("\nFolder structure creation process finished.")

# --- Optional: Create empty placeholder files ---
# If you also want to create the .dart files mentioned in the structure
# uncomment the section below.

# files_to_touch = [
#     "lib/main.dart",
#     "lib/core/constants/colors.dart",
#     "lib/core/constants/dimensions.dart",
#     "lib/core/themes/app_theme.dart",
#     "lib/presentation/screens/bus_map_screen.dart",
#     "lib/presentation/widgets/bus_stop_marker.dart",
#     "lib/presentation/widgets/bus_schedule_list.dart",
#     "lib/presentation/widgets/bus_schedule_item.dart",
#     "lib/presentation/widgets/animated_loading_indicator.dart",
#     "lib/presentation/widgets/bus_refresh_button.dart",
#     "lib/presentation/blocs/bus_schedule_bloc.dart",
#     "lib/domain/models/bus_stop.dart",
#     "lib/domain/models/bus_schedule.dart",
#     "lib/domain/repositories/bus_schedule_repository.dart",
#     "lib/domain/usecases/get_bus_schedules_for_stop.dart",
#     "lib/data/repositories/bus_schedule_repository_impl.dart",
#     "lib/data/datasources/bus_schedule_local_data_source.dart",
#     "lib/data/datasources/bus_schedule_remote_data_source.dart",
# ]

# print("\nCreating placeholder files...")
# for file_path in files_to_touch:
#     full_file_path = os.path.join(base_dir, file_path)
#     try:
#         # Create the file if it doesn't exist, don't overwrite if it does
#         if not os.path.exists(full_file_path):
#             with open(full_file_path, 'w') as f:
#                 pass # Just create an empty file
#             print(f"Successfully created file: {full_file_path}")
#         else:
#             print(f"File already exists, skipped: {full_file_path}")
#     except OSError as e:
#         print(f"Error creating file {full_file_path}: {e}")

# print("\nPlaceholder file creation process finished.")