(ns pixie.ffi-infer
  (require pixie.io :as io))

(defmulti emit-infer-code :op)

(defmethod emit-infer-code :constant
  [{:keys [name]}]
  (str "std::cout << \"{:name " (keyword name)" :value \" << " name
       "<< \" :type \" << TypeOf( " name ") "
       "<< \"}\" << std::endl; \n"))

(defmethod emit-infer-code :sizeof-struct
  [{:keys [name]}]
  (str "std::cout << \"{:name " (keyword name)" :sizeof \" << sizeof(struct " name
       ") << \"}\" << std::endl; \n"))

(defmethod emit-infer-code :sizeof
  [{:keys [name]}]
  (str "std::cout << \"{:name " (keyword name)" :sizeof \" << sizeof( " name
       ") << \"}\" << std::endl; \n"))

(defmethod emit-infer-code :offsetof-struct
  [{:keys [struct-name member-name]}]
  (str "std::cout << \"{:name " (keyword member-name)" :offsetof \" << offsetof(struct " struct-name ", "
       member-name
       ") << \"}\" << std::endl; \n"))

(defmethod emit-infer-code :group
  [{:keys [ops]}]
  (str "std::cout << \"[\" << std::endl; "
       (apply str (map emit-infer-code ops))
       "std::cout << \"]\" << std::endl; "))

(defn start-string []
  " #include <stdio.h>
    #include <stdlib.h>
    #include <sys/stat.h>
      #include <iostream>

    template <typename T>
    std::string TypeOf(T v)
    {
      return \":unknown\";
    }

    template<>
    std::string TypeOf<size_t>(size_t v)
    {
      return \":CSizeT\";
    }

    template<>
    std::string TypeOf<int>(int v)
    {
      return \":CIntT\";
    }

      int main() {
      std::cout << \"[\";
")

(defn end-string []
  " std::cout << \"]\" << std::endl;
    return 0;
      }")


(io/spit "/tmp/tmp.cpp" (str (start-string)
                             (apply str (map emit-infer-code
                                             [ {:op :constant :name "RAND_MAX"}
                                               {:op :sizeof :name "int"}
                                               {:op :group
                                                :ops [ {:op :sizeof-struct :name "stat"}
                                                       {:op :offsetof-struct :struct-name "stat" :member-name "st_size"}]}]))
                                 (end-string)))

(do (io/spit "/tmp/tmp.cpp" (str (start-string)
                             (apply str (map emit-infer-code
                                             [ {:op :constant :name "RAND_MAX"}
                                               {:op :sizeof :name "int"}
                                               {:op :group
                                                :ops [ {:op :sizeof-struct :name "stat"}
                                                       {:op :offsetof-struct :struct-name "stat" :member-name "st_size"}]}]))
                                 (end-string)))
    (read-string (io/run-command "c++ /tmp/tmp.cpp && ./a.out")))

(spit )
(io/run-command "ls")
