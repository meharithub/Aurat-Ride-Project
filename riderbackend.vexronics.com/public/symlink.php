<?php

$target = '/home/vexrgehf/riderbackend.vexronics.com/storage/app/public';
$link = '/home/vexrgehf/riderbackend.vexronics.com/public/storage';

// Delete old symlink if exists
if (is_link($link) || file_exists($link)) {
    unlink($link);
}

// Create new symlink
if (symlink($target, $link)) {
    echo "Symlink created successfully";
} else {
    echo "Failed to create symlink";
}
