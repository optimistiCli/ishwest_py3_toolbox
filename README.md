# Ish West Python 3 Toolbox

## Sub-modules
### Module iwp3tb.ancestors
A handy iterator through a class' custom ancestors.
#### Example
```python
from iwp3tb import Ancestors

from andere.plek import Oma

class Gran():
    pass

class Dad(Gran):
    pass

class Mom(Oma):
    pass

class Son(Dad, Mom):
    pass

for cls in Ancestors(Son):
    print(cls.__name__)

# prints out:
# Son
# Dad
# Gran
# Mom
# Oma
```
#### Classes
`Ancestors(a_class: type, a_include_self: bool = True)`
:   An iterator for non-builtin ancestors of a class
    
    Goes recursively through all custom (i.e. not builtin) classes that
    the base class inherits from. The base class itself comes first in the 
    iteration otherwise the order is unpredictable. Pass False as a second 
    argument to the constructor to avoid including the base class in the 
    iteration.
    
    Parameters
    ----------
    a_class : type
        The base class, who's ancestors we want to iterate through
    a_include_self : bool, optional
        If True the base class itself is included in the iteration, 
        otherwise immedeatly proceeds to base class' ancestors. Defaults 
        to True

### Module iwp3tb.multiton
A set of handy decorators for my beloved Singleton and Multiton design patterns.
#### Concept
A multiton here is an abstract class, that has a finite number of 
implementations. Each implementation is instantiated just once and this
instance is made available as an attribute of the parent multiton 
class.

A singleton is basically a multiton that has only one implementation. 
Thus no need to separate the abstract class from private 
implementation.

This approach allows for very private implementations while 
only the common interface becomes public.
#### Examples
##### Basic Multiton

```python
from iwp3tb import multiton, implementation

@multiton
class PowerRaiser():
    def raise_to_power(self, x: float) -> float:
        # This is an abstract method.
        # Implementations should realise it.
        raise Exception('You should have implemented this!')

@implementation
class Second(PowerRaiser):
    def raise_to_power(self, x):
        return x * x

@implementation
class Third(PowerRaiser):
    def raise_to_power(self, x):
        return x * x * x

print(PowerRaiser.Second.raise_to_power(3))
# prints out:
# 9

print(PowerRaiser.Third.raise_to_power(3))
# prints out:
# 27
```

##### Custom Multiton

Arbitrary instance names can be used.

```python
from iwp3tb import multiton, implementation_named

@multiton
class PowerRaiser():
    def raise_to_power(self, x: float) -> float:
        # This is an abstract method.
        # Implementations should realise it.
        raise Exception('You should have implemented this!')

@implementation_named('power2')
class Second(PowerRaiser):
    def raise_to_power(self, x):
        return x * x

@implementation_named('power3')
class Third(PowerRaiser):
    def raise_to_power(self, x):
        return x * x * x

print(PowerRaiser.power2.raise_to_power(3))
# prints out:
# 9

print(PowerRaiser.power3.raise_to_power(3))
# prints out:
# 27
```

##### Singleton

```python
from iwp3tb import singleton

@singleton
class Squarer():
    def to_square(self, x: float) -> float:
        return x * x

print(Squarer.instance.to_square(3))
# prints out:
# 9
```
#### Functions
`implementation(cls)`
:   Class decorator that registers an implementation with a multiton 
    ancestor class. Class name is used for the implementation instance name. 
    The class name must not conflict with any of the multition attributes.

    
`implementation_named(a_name)`
:   Class decorator that registers an implementation with a multiton 
    ancestor class using a custom instance name. The class name must not 
    conflict with any of the multition attributes.

    
`multiton(cls)`
:   Class decorator for multiton. A multiton class should have no multition 
    or singleton ancestors.

    
`singleton(cls)`
:   Class decorator for singleton. A singleton class should have no 
    multition or singleton ancestors.
#### Classes
`AlreadyHasRegistrarParent(a_class, a_registrar)`
:   An error raised if a class is decorated as an multiton but it already has a 
    multiton parent.
    
    ```python
    from iwp3tb import multiton
    
    @multiton
    class GoodMultiton():
        pass
    
    @multiton
    class BadMultiton(GoodMultiton):
        pass
    # Raises AlreadyHasRegistrarParent
    ```

    ##### Ancestors (in MRO)

    * iwp3tb.multiton.MultitonError
    * builtins.Exception
    * builtins.BaseException

`MultitonError(a_string)`
:   Common base class for multiton fatal errors.

    ##### Ancestors (in MRO)

    * builtins.Exception
    * builtins.BaseException

    ##### Descendants

    * iwp3tb.multiton.AlreadyHasRegistrarParent
    * iwp3tb.multiton.NoRegistrarParent
    * iwp3tb.multiton.RegistrarAlreadyHasAttribute

`NoRegistrarParent(a_class)`
:   An error raised if a class is decorated as an implementation but it has no 
    multiton parent.
    
    ```python
    from iwp3tb import implementation
    
    @implementation
    class BadImplementation():
        pass
    # Raises NoRegistrarParent
    ```

    ##### Ancestors (in MRO)

    * iwp3tb.multiton.MultitonError
    * builtins.Exception
    * builtins.BaseException

`RegistrarAlreadyHasAttribute(a_class, a_registrar, a_name)`
:   An error raised if a naming conflict happens while registering an implementation 
    with a multiton.
    
    ```python
    from iwp3tb import multiton, implementation, implementation_named
    
    @multiton
    class GoodMultiton():
        pass
    
    @implementation
    class GoodImplementation(GoodMultiton):
        pass
    
    @implementation_named('GoodImplementation')
    class BadImplementation(GoodMultiton):
        pass
    # Raises RegistrarAlreadyHasAttribute
    ```

    ##### Ancestors (in MRO)

    * iwp3tb.multiton.MultitonError
    * builtins.Exception
    * builtins.BaseException
## Tools
`gendocs.sh`
:   Generates html documentation from source files using [pdoc](https://pdoc3.github.io/pdoc/).

`runtests.sh`
:   Runs unit tests.

