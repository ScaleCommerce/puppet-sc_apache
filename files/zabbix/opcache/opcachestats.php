<?php

class OPcacheStats {
        private $data;

        function __construct()
        {
                $this->checkEnv();
                $this->buildArray();
        }

        // test whether OPcache extension is installed
        protected function checkEnv()
        {
                if (!function_exists('opcache_get_status')) {
                        throw new Exception("The Zend OPcache extension does not appear to be installed.", 1);
                }
        }

        // build array with information about memory and statistics
        protected function buildArray()
        {
                $opcache_config = opcache_get_configuration();
                $opcache_status = opcache_get_status();

                $this->data = array_merge(
                        $opcache_status['memory_usage'],
                        $opcache_status['opcache_statistics'],
                        array(
                                'total_memory_size'       => $opcache_config['directives']['opcache.memory_consumption'],
                                'used_memory_percentage'  => round(100 * (
                                ($opcache_status['memory_usage']['used_memory'] + $opcache_status['memory_usage']['wasted_memory'])
                                / $opcache_config['directives']['opcache.memory_consumption'])),
                                'hit_rate_percentage'     => round($opcache_status['opcache_statistics']['opcache_hit_rate']),
                                'wasted_percentage'       => round($opcache_status['memory_usage']['current_wasted_percentage'], 2),
                                'used_memory_size'        => $opcache_status['memory_usage']['used_memory'],
                                'free_memory_size'        => $opcache_status['memory_usage']['free_memory'],
                                'wasted_memory_size'      => $opcache_status['memory_usage']['wasted_memory'],
                                'files_cached'            => $opcache_status['opcache_statistics']['num_cached_scripts'],
                                'hits_size'               => $opcache_status['opcache_statistics']['hits'],
                                'miss_size'               => $opcache_status['opcache_statistics']['misses'],
                                'blacklist_miss_size'     => $opcache_status['opcache_statistics']['blacklist_misses'],
                                'num_cached_keys_size'    => $opcache_status['opcache_statistics']['num_cached_keys'],
                                'max_cached_keys_size'    => $opcache_status['opcache_statistics']['max_cached_keys'],
                        )
                );
        }

        public function getTotalMemorySize() {
                return $this->data['total_memory_size'];
        }
        public function getUsedMemoryPercentage() {
                return $this->data['used_memory_percentage'];
        }
        public function getHitRatePercentage() {
                return $this->data['hit_rate_percentage'];
        }
        public function getWastedPercentage() {
                return $this->data['wasted_percentage'];
        }
        public function getUsedMemorySize() {
                return $this->data['used_memory_size'];
        }
        public function getFreeMemorySize() {
                return $this->data['free_memory_size'];
        }
        public function getWastedMemorySize() {
                return $this->data['wasted_memory_size'];
        }
        public function getFilesCached() {
                return $this->data['files_cached'];
        }
        public function getHitsSize() {
                return $this->data['hits_size'];
        }
        public function getMissSize() {
                return $this->data['miss_size'];
        }
        public function getBlacklistMissSize() {
                return $this->data['blacklist_miss_size'];
        }
        public function getNumCachedKeysSize() {
                return $this->data['num_cached_keys_size'];
        }
        public function getMaxCachedKeysSize() {
                return $this->data['max_cached_keys_size'];
        }

}
