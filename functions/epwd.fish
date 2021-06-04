function epwd -d "Output the current working directory relative to environment variables"
  # Regex for filtering environment variables with valid paths (excluding PWD)
  set filter_regex '^(?!PWD)([A-Z0-9_]+)\=(/(?:[^\0 !$`&*()+:]|\(\ |\!|\$|\`|\&|\*|\(|\)|\+\))+)$'

  set all_paths (printenv | string match -r $filter_regex | awk 'NR % 3 == 0')

  set i 1
  set path_len 0
  for p in $all_paths
    # Remove the trailing slash
    set without_dangling_slash (echo $p | string match -r '(.*)/$' | awk 'NR == 2')
    if test "$without_dangling_slash" != ""
      set p $without_dangling_slash
    end

    # Find the longest matching variable
    set path_test (pwd | grep '^'$p)
    if test "$path_test" != ""
      set tmp_len (string length $p)
      if test $tmp_len -gt $path_len
        set path_matched $p
        set path_env_index $i
        set path_len $tmp_len
      end
    end
    set i (math $i + 1)
  end

  if test "$path_matched" != ""
    set path_var '$'(printenv | string match -r $filter_regex | awk 'NR % 3 == 2' | awk 'NR == '$path_env_index)
    echo (string replace $path_matched $path_var (pwd))
  else
    pwd
  end
end
