# Стенд nginx + srcache moudle

Transparent subrequest-based caching layout for arbitrary nginx locations

Позволяет работать с key=value db, такими как memcached/redis

https://github.com/openresty/srcache-nginx-module

# Todo

- включить кеширование 40x
- меньшее время кеширования 40x (можно сделать мапой)
- протестировать скорость redis1 redis2, убрать поддержку redis1 (яндекс танком например) добавить в заголовок время выполнения запроса
- разобраться с максимальным размером файла для кеша
- разобраться с md5 для именования ключей
- добавить хидер Host в боди кеша
- подогнать под конфиг static-cache
- собрать стенд с static-cache, дунуть реального трафену
- для прода выключить логи по максимуму
