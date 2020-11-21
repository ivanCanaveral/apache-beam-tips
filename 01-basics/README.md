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