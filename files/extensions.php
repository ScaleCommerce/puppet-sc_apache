<?php
$extensions=get_loaded_extensions();
foreach ($extensions as $key => $value) {
  print $value;
}
?>
