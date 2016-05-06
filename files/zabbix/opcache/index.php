<?php
include 'opcachestats.php';

$opstats = new OPCacheStats();
echo "total_memory_size " . $opstats->getTotalMemorySize() . "\n";
echo "used_memory_percentage " . $opstats->getUsedMemoryPercentage() . "\n";
echo "hit_rate_percentage " . $opstats->getHitRatePercentage() . "\n";
echo "wasted_percentage " . $opstats->getWastedPercentage() . "\n";
echo "used_memory_size " . $opstats->getUsedMemorySize() . "\n";
echo "free_memory_size " . $opstats->getFreeMemorySize() . "\n";
echo "wasted_memory_size " . $opstats->getWastedMemorySize() . "\n";
echo "files_cached " . $opstats->getFilesCached() . "\n";
echo "hits_size " . $opstats->getHitsSize() . "\n";
echo "miss_size " . $opstats->getMissSize() . "\n";
echo "blacklist_miss_size " . $opstats->getBlacklistMissSize() . "\n";
echo "num_cached_keys_size " . $opstats->getNumCachedKeysSize() . "\n";
echo "max_cached_keys_size " . $opstats->getMaxCachedKeysSize() . "\n";
