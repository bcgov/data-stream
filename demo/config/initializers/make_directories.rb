require 'fileutils'
written_files_dir = Rails.root.join("lib","services","written_files")
description_dir = Rails.root.join("lib","services","written_files","i2loc_file")
skeleton_dir = Rails.root.join("lib","services","written_files","skeleton")
muscle_dir = Rails.root.join("lib","services","written_files","muscle")
joint_dir = Rails.root.join("lib","services","written_files","joint")
digestive_dir = Rails.root.join("lib","services","written_files","digestive")
respiratory_dir = Rails.root.join("lib","services","written_files","respiratory")
endocrine_dir = Rails.root.join("lib","services","written_files","endocrine")
circulatory_system_heart_dir = Rails.root.join("lib","services","written_files","circulatory_system_heart")
urogenital_dir = Rails.root.join("lib","services","written_files","urogenital")
lymphatic_dir = Rails.root.join("lib","services","written_files","lymphatic")
central_nervous_system_dir = Rails.root.join("lib","services","written_files","central_nervous_system")
peripheral_nervous_system_dir = Rails.root.join("lib","services","written_files","peripheral_nervous_system")
circulatory_system_arteries_dir = Rails.root.join("lib","services","written_files","circulatory_system_arteries")
circulatory_system_veins_dir = Rails.root.join("lib","services","written_files","circulatory_system_heart")



test_dir = Rails.root.join("lib","services","test_files")
test_skeleton_dir = Rails.root.join("lib","services","test_files","skeleton")


FileUtils::mkdir_p written_files_dir
FileUtils::mkdir_p description_dir
FileUtils::mkdir_p skeleton_dir
FileUtils::mkdir_p muscle_dir
FileUtils::mkdir_p joint_dir
FileUtils::mkdir_p digestive_dir
FileUtils::mkdir_p respiratory_dir
FileUtils::mkdir_p endocrine_dir
FileUtils::mkdir_p circulatory_system_heart_dir
FileUtils::mkdir_p urogenital_dir
FileUtils::mkdir_p lymphatic_dir
FileUtils::mkdir_p central_nervous_system_dir
FileUtils::mkdir_p peripheral_nervous_system_dir
FileUtils::mkdir_p circulatory_system_arteries_dir
FileUtils::mkdir_p circulatory_system_veins_dir
FileUtils::mkdir_p test_dir
FileUtils::mkdir_p test_skeleton_dir
