# Basics

## PCollections

**PCollections** are potentially-distributed abstractions that represents a data set.

* A **PCpllection** is owned by a specific **Pipeline**, and cannot be shared between different Pipelines.
* The elements of a **PCollection** must all be of the same type, and that type must be encodable as a byte string (so elements can be sent to distributed workers)
* A **PCollection** has a structure that can be instrospected (like JSON, Protocol Buffer, etc).
* A **PCollection** is immutable. Each transformation creates a new one.
* **PCollections** do not support random access to individual elements.
* **PCollections** can be *bounded* or *unbounded*. Reading from a batch data source creates a *bounded* one, and reading from a streaming source (like kafka) creates a *unbounded* **PCollection**.
* Beam uses *windowing* to divide a continously updating unbounded **PCollection**. These windows are deterined by some characteristics, such as a timestamp, and aggregation transforms process this kind of **PCollection** as a sucession of finite windows.
* Every element in a **PCollection** has a timestamp. Usually, that timestamp is the time when the element was readed or loaded.

## Transforms

**Transforms** are the operations in our pipeline, that takes the following general form:

```python
[output PCollection] = [Input PCollection] | [Transform]
```

Transforms can be chained also:

```python
[Final Output PCollection] = (
    [Initial Input PCollection] 
        | [First Transform]
        | [Second Transform]
        | [Third Transform]
    )
```

We can apply several **Transforms** to the same collection to create a branching pipeline.

### ParDo

Apply computations on each element of the dataset. If you want to apply a `ParDo` computation, your code should be an instace of `DoFn`, which defines a distributed function. It should follow this structure:

```python
class MyFn(beam.DoFn):
  def process(self, element):
    return iterable / yield element
```

If the elements are key-value pairs, we can use `element.getKey()` and `element.getValue()` to get them.

* **Idempotence**: Our functions may be invoked multiple times on a given worker node to ennsure for failure recovery. We should make sure the implementation does not depend on the number of invocations.
* **Immutability**: We should not modify the `element` object.

### Maps

If your `DoFn` is quite simple, you can use higher order funcitions like `Map` or `FlatMap`.

### GroupByKey

Gruops by key, and collects the values. For example, if we apply a GroupByKey to the following data

```
a, 1
b, 2
a, 3
b, 4
```

we get:

```
a, [1,3]
b, [2,4]
```

### CoGroupByKey

Applies a `GroupByKey` using data from different PCollections. The result is a dictionary with all the gruped elements per collection:

```
('a', {'singles': [4, '1'], 'couples': ['11']})
('b', {'singles': ['2'], 'couples': ['22']})
('c', {'singles': ['3'], 'couples': ['33']})
```

### Combine

Combines a set of values from a **PCollection**, given a function that defines the way to combine elements.

This function should be *asociative* and *commutative*, two basic requirements for this kind of reducing parallelizations.

As for `DoPar`, if our combining logic is complex, we can write an scpecific subclass of `beam.CombineFn`.

We can use uses `CombineGlobally` or `CombinePerKey`.

For a custom Combiner, we will need to implement four methods:

```python
class AverageFn(beam.CombineFn):
  def create_accumulator(self):
    ...

  def add_input(self, accumulator, input):
    ...

  def merge_accumulators(self, accumulators):
    ...

  def extract_output(self, accumulator):
    ...
```